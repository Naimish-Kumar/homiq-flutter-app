enum PackageType {
  propertyList('property_list', title: 'propertyListTitle', description: 'propertyListDescription'),
  propertyFeature('property_feature', title: 'propertyFeatureTitle', description: 'propertyFeatureDescription'),
  projectList('project_list', title: 'projectListTitle', description: 'projectListDescription'),
  projectFeature('project_feature', title: 'projectFeatureTitle', description: 'projectFeatureDescription'),
  premiumProperties('premium_properties', title: 'premiumPropertiesTitle', description: 'premiumPropertiesDescription'),
  projectAccess('project_access', title: 'projectAccessTitle', description: 'projectAccessDescription'),
  project('project_access', title: 'projectAccessTitle', description: 'projectAccessDescription'),
  property('property_list', title: 'propertyListTitle', description: 'propertyListDescription'),
  designGeneration('design_generation', title: 'designGenerationTitle', description: 'designGenerationDescription');

  final String value;
  final String title;
  final String description;
  const PackageType(this.value, {required this.title, required this.description});

  bool get checkLimit => this == PackageType.propertyList || this == PackageType.projectList;
  bool get checkFeature => this == PackageType.propertyFeature || this == PackageType.projectFeature;
}
